#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ PARAM    ณ Autor ณ Adilson Silva         ณ Data ณ 19.06.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cadastramento Alternativo de Funcionarios                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function PARAM()

Private aRotina,cCadastro

Private aRotina := { {"Pesquisar"  ,"AxPesqui"  ,0  ,1} ,;
                     { "Visualizar" ,"U_Param1"  ,0  ,2} ,;
                     { "Atualizar"  ,"U_Param1"  ,0  ,4} ,;
                     { "Excluir"    ,"U_Param1"  ,0  ,5}   }

cCadastro := OemToAnsi("Parametros Auxiliares")

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

//Filtra Apenas os Dados Que Contenham a Descricao do Parametro
dbSelectArea("SZJ")
SZJ->(dbSetFilter({|| !Empty(SZJ->ZJ_DESCR)},"!Empty(SZJ->ZJ_DESCR)"))

dbGoTop()

//Ativa o Browse 
mBrowse( 6, 1,22,75,"SZJ" )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPARAM1    บAutor  ณAdilson Silva       บ Data ณ  08/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Edicao em aCols dos Parametros Auxiliares.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Param1(cAlias,nReg,nOpcx)

Private xFilial,xCodigo,xDescr,xAlias,cTit,cTxt,nUsado,aHeader,aCols,nCont,nTit,nTxt,aC,aR,cTitulo,aCgd,cLinhaOK,cTudoOK

//Inicia variaveis
xFilial  := ZJ_FILIAL
xCodigo  := ZJ_CODIGO
xDescr   := ZJ_DESCR
xAlias   := ZJ_ARQUIVO
cTitulo  := "" 
cLinhaOK := ""
cTudoOK  := ""
nUsado   := 0
nCont    := 0
nTit     := 0
nTxt     := 0
aHeader  := {}
aCols    := {}
aC       := {}
aR       := {}
aCGD     := {}
lInclui  := .T.

// Deleta Filtro 
SZJ->(dbClearFilter())

_aAre := GetArea()

dbSelectArea("SZJ")
dbSeek(xFilial+xAlias+xCodigo)

Do While !Eof() .And. SZJ->ZJ_FILIAL+xAlias+SZJ->ZJ_CODIGO == xFilial+xAlias+xCodigo

   nUsado++
   AADD(aHeader,{TRIM( ZJ_TITULO) ,;
                        ZJ_CAMPO    ,;
                        ZJ_PICTURE  ,;
                        ZJ_TAMANHO  ,;
                        ZJ_DECIMAL  ,;
                                    ,;
                                    ,;
                        ZJ_TIPO     ,;
                        ZJ_ARQUIVO  ,;
                                    ,;
                        ZJ_ETIT     ,;
                        ZJ_OBRIGA       } ) 
                    
   dbSkip()
EndDo

//Montagem do aCols
nUsado := 0
dbSelectArea("SZK")
dbSeek( xFilial+xCodigo )
lInclui := .T.
Do While !Eof() .And. SZK->ZK_FILIAL+SZK->ZK_TIP == xFilial+xCodigo
   nCont++
   nTit := 1
   nTxt := 1
   Aadd(aCols,{})
   For i := 1 To Len(aHeader)
       nUsado := nUsado + 1
       If aHeader[i,11] == "S"
          If aHeader[i,8] == "C"
             Aadd( aCOLS[nCont],SubStr(SZK->ZK_CODIGO,nTit,(aHeader[i,04]) ) )
          ElseIf aHeader[i,8] == "N"
             Aadd( aCOLS[nCont],Val(SubStr(SZK->ZK_CODIGO,nTit,(aHeader[i,04])))  )
          ElseIf aHeader[i,8] == "D"
             Aadd( aCOLS[nCont],Ctod(SubStr(SZK->ZK_CODIGO,nTit,(aHeader[i,04]))) )
          EndIf
          nTit += (aHeader[i,04])
       Else
          If aHeader[i,8] == "C"
             Aadd( aCOLS[nCont],SubStr(SZK->ZK_TXT,nTxt,(aHeader[i,04]))  )
          ElseIf aHeader[i,8] == "N"
             Aadd( aCOLS[nCont],Val(SubStr(SZK->ZK_TXT,nTxt,(aHeader[i,04])))  )
          ElseIf aHeader[i,8] == "D"
             Aadd( aCOLS[nCont],Ctod(SubStr(SZK->ZK_TXT,nTxt,(aHeader[i,04]))) )
          EndIf
          nTxt += (aHeader[i,04])
       EndIf
       lInclui := .F.
   Next
   Aadd(aCOLS[nCont],.F.)
   dbSkip()
EndDo       

If lInclui
   nCont++
   Aadd(aCols,{})
   For i := 1 To Len(aHeader)
       nUsado := nUsado + 1
       If aHeader[i,8] == "C"
          Aadd(aCOLS[nCont],Space(aHeader[i,4]))
       ElseIf aHeader[i,8] == "N"
          Aadd(aCOLS[nCont],0)
       ElseIf aHeader[i,8] == "D"
          Aadd(aCOLS[nCont],Ctod(Space(8)))
       EndIf
   Next
   Aadd(aCOLS[nCont],.F.)
EndIf

cTitulo:="Parametros Auxiliares"

//Array com descricao dos campos do Cabecalho do Modelo 2
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

AADD(aC,{"xCodigo" ,{15,010},"Codigo"    ,"@!"   ,,     ,.F.})
AADD(aC,{"xDescr"  ,{15,050},"Descricao" ,"@!S38",,     ,.F.})
    
//Array com descricao dos campos do Rodape do Modelo 2
aR := {}

//Array com coordenadas da GetDados no modelo2
aCGD:={34,5,118,315}

//Validacoes na GetDados da Modelo 2
cLinhaOk  := "U_fLinOk()"   
cTudoOk   := ""           

//Chamada da Modelo2
lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk) 

// Verifica se Confirmou as Informacoes
If lRetMod2 .And. Len(aCols) > 0 .And. nOpcx # 2
   dbSelectArea("SZK")
   dbSeek( xFilial+xCodigo )
   Do While !Eof() .And. SZK->ZK_FILIAL+SZK->ZK_TIP == xFilial+xCodigo
      RecLock("SZK",.F.)
        dbDelete()
      MsUnlock()
      dbSkip()
   EndDo
   
   For i := 1 To Len(aCols)
       If aCols[i,Len(aCols[i])]
          Loop
       EndIf
       cTit := ''
       cTxt := ''
       For o := 1 To Len(aHeader)
           If aHeader[o,11] == "S"
              If aHeader[o,08] == "C"
                 cTit += aCols[i,o]
              ElseIf aHeader[o,08] == "N"
                 cTit += Str(aCols[i,o],aHeader[o,04],aHeader[o,05])
              ElseIf aHeader[o,08] == "D"
                 cTit += Dtoc(aCols[i,o])
              EndIf
           Else
              If aHeader[o,08] == "C"
                 cTxt += aCols[i,o]
              ElseIf aHeader[o,08] == "N"
                 cTxt += Str(aCols[i,o],aHeader[o,04],aHeader[o,05])
              ElseIf aHeader[o,08] == "D"
                 cTxt += Dtoc(aCols[i,o])
              EndIf
           EndIf
       Next
       RecLock("SZK",.T.)
        SZK->ZK_TIP    := xCodigo
        SZK->ZK_CODIGO := cTit
        SZK->ZK_TXT    := cTxt
       MsUnlock()
   Next
Endif

//Restaura Filtro da Rotina Inicial.
SZJ->(dbSetFilter({|| !Empty(SZJ->ZJ_DESCR)},"!Empty(SZJ->ZJ_DESCR)"))

RestArea(_aAre)
dbGoTo(nReg)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLinOk    บAutor  ณAdilson Silva       บ Data ณ  08/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao das Linhas do aCols.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
User Function fLinOk()

Local lRet := .T.
nLin:=n

For a := 1 To Len(aHeader)
    If aCols[nLin,Len(aCols[nLin])]
       Loop
    EndIf
    //Campo Obrigatorio
    If aHeader[a,12] == "S" 
       If Empty(aCols[nLin,a])
          lRet := .F.
       EndIf
    EndIf
    
Next

If !lRet
   MsgStop("Nao Foram Preenchidos Campos Obrigatorios!!!")
EndIf

Return(lRet)	

//Fim da Rotina

//Fim do Programa


#Include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MapaUsu  º Autor ³Carlos G. Berganton º Data ³  16/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mapeia Acessos dos Usuarios do Sistema                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MapaUsu()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local aOrd           := {"ID Usuario","Nome Usuario"}
Private titulo       := "Relatorio de Acessos dos Usuarios"
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private tamanho      := "M"
Private nomeprog     := "MapaUsu" 
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
//Private cPerg        := "MAPAUS"
Private m_pag        := 01
Private wnrel        := "MapaUsu"
Private cString      := ""
// FPADR(cPerg, cArq, cCampo, cTipo)
PRIVATE cPerg  	:= U_FPADR( "MAPAUS","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustSXB()

AjustaSX1(cPerg)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  16/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem   := aReturn[8]
Local aIdiomas := {"Portugues","Ingles","Espanhol"}
Local aTipoImp := {"Em Disco","Via Spool","Direto na Porta","E-Mail"}
Local aFormImp := {"Retrado","Paisagem"}
Local aAmbImp  := {"Servidor","Cliente"}
Local aColAcess:= {000,040,080}
Local aColMenus:= {000,044,088}
Local aAllUsers:= AllUsers()
Local aUser    := {}
Local i        := 0
Local k        := 0
Local j        := 0
Local aMenu    

aModulos := fModulos()
aAcessos := fAcessos()

For i:=1 to len(aAllUsers)
	lFiltroGrp := .F.
	If	aAllUsers[i][01][01]>=mv_par01 .and. aAllUsers[i][01][01]<=mv_par02 .and.;
		aAllUsers[i][01][02]>=mv_par03 .and. aAllUsers[i][01][02]<=mv_par04
   		
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Se o usuario nao tiver um grupo, inclui um elemento vazio ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If Len(aAllUsers[i][01][10])==0
   	   aAdd(aAllUsers[i][01][10],Space(06))
   	Endif   
   		
   	For k := 1 to Len(aAllUsers[i][01][10])
		   If aAllUsers[i][01][10][k] >= mv_par05 .and.;
			   aAllUsers[i][01][10][k] <= mv_par06
  		      aAdd(aUser,aAllUsers[i])
		   Endif
		Next k
	Endif   
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indexa Aray ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem==1 //ID
   aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][1] < aVar2[1][1]})
Else         //Usuario
   aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][2] < aVar2[1][2]})
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Len(aUser))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Usuarios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aUser)
   IncRegua()

   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 5
  
   @ nLin,000 pSay "I N F O R M A C O E S   D O   U S U A R I O"
   nLin+=1
   @ nLin,000 pSay "User ID.........................: "+aUser[i][01][01] //ID
   nLin+=1
   @ nLin,000 pSay "Usuario.........................: "+aUser[i][01][02] //Usuario
   nLin+=1
   @ nLin,000 pSay "Nome Completo...................: "+aUser[i][01][04] //Nome Completo
   nLin+=1
   @ nLin,000 pSay "Validade........................: "+DTOC(aUser[i][01][06]) //Validade
   nLin+=1
   @ nLin,000 pSay "Acessos para Expirar............: "+AllTrim(Str(aUser[i][01][07])) //Expira em n acessos
   nLin+=1
   @ nLin,000 pSay "Autorizado a Alterar Senha......: "+If(aUser[i][01][08],"Sim","Nao") //Autorizado a Alterar Senha
   nLin+=1
   @ nLin,000 pSay "Alterar Senha no Proximo LogOn..: "+If(aUser[i][01][09],"Sim","Nao") //Alterar Senha no Proximo LogOn
   nLin+=1

   PswOrder(1)
   PswSeek(aUser[i][1][11],.t.)
   aSuperior := PswRet(NIL)
   @ nLin,000 pSay "Superior........................: "+If(!Empty(aSuperior),aSuperior[01][02],"") //Superior
   nLin+=1
   @ nLin,000 pSay "Departamento....................: "+aUser[i][01][12] //Departamento
   nLin+=1
   @ nLin,000 pSay "Cargo...........................: "+aUser[i][01][13] //Cargo
   nLin+=1
   @ nLin,000 pSay "E-Mail..........................: "+aUser[i][01][14] //E-Mail
   nLin+=1
   @ nLin,000 pSay "Acessos Simultaneos.............: "+AllTrim(Str(aUser[i][01][15])) //Acessos Simultaneos
   nLin+=1
   @ nLin,000 pSay "Ultima Alteracao................: "+DTOC(aUser[i][01][16]) //Data da Ultima Alteracao
   nLin+=1
   @ nLin,000 pSay "Usuario Bloqueado...............: "+If(aUser[i][01][17],"Sim","Nao") //Usuario Bloqueado
   nLin+=1
   @ nLin,000 pSay "Digitos p/o Ano.................: "+AllTrim(STR(aUser[i][01][18])) //Numero de Digitos Para o Ano
   nLin+=1
   @ nLin,000 pSay "Idioma..........................: "+aIdiomas[aUser[i][02][02]] //Idioma
   nLin+=1
   @ nLin,000 pSay "Diretorio do Relatorio..........: "+aUser[i][02][03] //Diretorio de Relatorio
   nLin+=1
   @ nLin,000 pSay "Tipo de Impressao...............: "+aTipoImp[aUser[i][02][08]] // Tipo de Impressao
   nLin+=1
   @ nLin,000 pSay "Formato de Impressao............: "+aFormImp[aUser[i][02][09]] // Formato
   nLin+=1
   @ nLin,000 pSay "Ambiente de Impressao...........: "+aAmbImp[aUser[i][02][10]] // Ambiente
   nLin+=2

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Grupos ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   @ nLin,000 pSay Replic("-",132)
   nLin+=1
   @nLin,000 pSay "G R U P O S"
   nLin+=2
   For k:=1 to Len(aUser[i][01][10])
      fCabec(@nLin,55)

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica se Grupo eh vazio, pois em casos do usuario nao ter nenhum grupo sera adicionado um elemento ³
      //³ no Array com Space(06) para poder serconsiderado                                                      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !Empty(aUser[i][01][10][k])
         PswOrder(1)
         PswSeek(aUser[i][01][10][k],.f.)
         aGroup := PswRet(NIL)

         @ nLin,005 pSay aGroup[01][2] //Grupos
         nLin+=1
      Endif   
   Next k
   nLin+=1

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Horarios ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If mv_par07==1
      fCabec(@nLin,50)

      @ nLin,000 pSay Replic("-",132)
      nLin+=1
      @nLin,000 pSay "H O R A R I O S"
      nLin+=2
      For k:=1 to Len(aUser[i][02][01])
         fCabec(@nLin,55)

         @ nLin,005 pSay aUser[i][2][01][k] //Horarios
         nLin+=1
      Next k
      nLin+=1
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Empresas / Filiais ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If mv_par08==1
      fCabec(@nLin,50)

      @ nLin,000 pSay Replic("-",132)
      nLin+=1
      @nLin,000 pSay "E M P R E S A S / F I L I A I S"
      nLin+=2
      For k:=1 to Len(aUser[i][02][06])
         fCabec(@nLin,55)

         dbSelectArea("SM0")
         dbSetOrder(1)
         dbSeek(aUser[i][02][06][k])
         @ nLin,005 pSay Substr(aUser[i][02][06][k],1,2)+"/"+Substr(aUser[i][02][06][k],3,2)+If(Found()," "+M0_NOME+" - "+M0_NOMECOM,If(Substr(aUser[i][02][06][k],1,2)=="@@"," - Todos","")) //Empresa / Filial
         nLin+=1
      
      Next k
      nLin+=1
   Endif
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Modulos ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If mv_par09==1
      fCabec(@nLin,50)

      @ nLin,000 pSay Replic("-",132)
      nLin+=1
      @ nLin,000 pSay "M O D U L O S"
      nLin+=2
      //                        1         2         3         4         5         6         7         8
      //               123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
      @ nLin,000 pSay "MODULO                                        NIVEL ARQ.MENU"
      nLin+=1
      @ nLin,000 pSay "--------------------------------------------- ----- --------------------------------------------"
      nLin+=1

      For k:=1 to Len(aUser[i][03])//Len(aModulos)
         If Substr(aUser[i][03][k],3,1) <> "X"
            If nLin > 58
               fCabec(@nLin,55)
               @ nLin,000 pSay "MODULO                                        NIVEL ARQ.MENU"
               nLin+=1
               @ nLin,000 pSay "--------------------------------------------- ----- --------------------------------------------"
               nLin+=1
            Endif
            
            nPos := aScan(aModulos,{|x| x[1]==Left(aAllUsers[i][03][k],2)})
            If !Empty(nPos)
               @ nLin,000 pSay aModulos[k][02]+" - "+aModulos[k][3]
               @ nLin,048 pSay Substr(aUser[i][03][k],3,1)
               @ nLin,052 pSay Substr(aUser[i][03][k],4)
               nLin+=1
            Endif
         Endif
      Next k
      nLin+=1
   Endif
        
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Acessos ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If mv_par10==1
      fCabec(@nLin,50)

      @ nLin,000 pSay Replic("-",132)
      nLin+=1
      @ nLin,000 pSay "A C E S S O S"
      nLin+=2

      nCol := 1
      For k:=1 to 103
         If Substr(aUser[i][02][5],k,1) == "S"
            fCabec(@nLin,55)
            @ nLin,aColAcess[nCol] pSay aAcessos[k]
            If nCol==3
               nCol:=1
               nLin+=1
            Else
               nCol+=1
            Endif
         Endif
      Next k
   Endif
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Imprime Menus ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If mv_par11==1
      fCabec(@nLin,50)

      @ nLin,000 pSay Replic("-",132)
      nLin+=1
      @ nLin,000 pSay "M E N U S"
      nLin+=2
      //                        1         2         3         4         5         6         7         8
      //               123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
      @ nLin,000 pSay "TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS"
      nLin+=1
      @ nLin,000 pSay "------------------ ---------- ----------    ------------------ ---------- ----------    ------------------ ---------- ----------"
      nLin+=1
      
      For k:=1 to Len(aUser[i][03])//Len(aModulos)
         If Substr(aUser[i][03][k],3,1) <> "X"
            aMenu := fGetMnu(Substr(aUser[i][03][k],4),aUser[i][01][02])
            
            aScan(aModulos,{|x| x[1]==Left(aUser[i][03][k],2)})
            If !Empty(nPos)
	            nLin +=1
	            @ nLin,000 pSay aModulos[k][02]+" - "+AllTrim(aModulos[k][3])+"  -->  "+Substr(aUser[i][03][k],4)
	            nLin+=2
           
               nCol := 1
               For j:=1 to Len(aMenu)
                  If nLin > 55
                     fCabec(@nLin,55)
                     @ nLin,000 pSay "TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS"
                     nLin+=1
                     @ nLin,000 pSay "------------------ ---------- ----------    ------------------ ---------- ----------    ------------------ ---------- ----------"
                     nLin+=1
                  Endif
       
                  If !(aMenu[j][4] $ "T|F")
                     Loop
                  Endif   
                  @ nLin,aColMenus[nCol]+000 pSay aMenu[j][02]
                  @ nLin,aColMenus[nCol]+019 pSay aMenu[j][03]
                  @ nLin,aColMenus[nCol]+030 pSay aMenu[j][06]
                  If nCol==3
                     nCol:=1
                     nLin+=1
                  Else
                     nCol+=1
                  Endif
               Next
               nLin+=1
            Endif
         Endif
      Next k
      nLin+=1
   Endif

   Roda(,,"M")
                
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fModulos ºAutor  ³Carlos G. Berganton º Data ³  16/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Array com Codigos e Nomes dos Modulos              º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fModulos()

Local aReturn

aReturn := {{"01","SIGAATF ","Ativo Fixo                       "},;
            {"02","SIGACOM ","Compras                           "},;
            {"03","SIGACON ","Contabilidade                     "},;
            {"04","SIGAEST ","Estoque/Custos                    "},;
            {"05","SIGAFAT ","Faturamento                       "},;
            {"06","SIGAFIN ","Financeiro                        "},;
            {"07","SIGAGPE ","Gestao de Pessoal                 "},;
            {"08","SIGAFAS ","Faturamento Servico               "},;
            {"09","SIGAFIS ","Livros Fiscais                    "},;
            {"10","SIGAPCP ","Planej.Contr.Producao             "},;
            {"11","SIGAVEI ","Veiculos                          "},;
            {"12","SIGALOJA","Controle de Lojas                 "},;
            {"13","SIGATMK ","Call Center                       "},;
            {"14","SIGAOFI ","Oficina                           "},;
            {"15","SIGARPM ","Gerador de Relatorios Beta1       "},;
            {"16","SIGAPON ","Ponto Eletronico                  "},;
            {"17","SIGAEIC ","Easy Import Control               "},;
            {"18","SIGAGRH ","Gestao de R.Humanos               "},;
            {"19","SIGAMNT ","Manutencao de Ativos              "},;
            {"20","SIGARSP ","Recrutamento e Selecao Pessoal    "},;
            {"21","SIGAQIE ","Inspecao de Entrada               "},;
            {"22","SIGAQMT ","Metrologia                        "},;
            {"23","SIGAFRT ","Front Loja                        "},;
            {"24","SIGAQDO ","Controle de Documentos            "},;
            {"25","SIGAQIP ","Inspecao de Projetos              "},;
            {"26","SIGATRM ","Treinamento                       "},;
            {"27","SIGAEIF ","Importacao - Financeiro           "},;
            {"28","SIGATEC ","Field Service                     "},;
            {"29","SIGAEEC ","Easy Export Control               "},;
            {"30","SIGAEFF ","Easy Financing                    "},;
            {"31","SIGAECO ","Easy Accounting                   "},;
            {"32","SIGAAFV ","Administracao de Forca de Vendas  "},;
            {"33","SIGAPLS ","Plano de Saude                    "},;
            {"34","SIGACTB ","Contabilidade Gerencial           "},;
            {"35","SIGAMDT ","Medicina e Seguranca no Trabalho  "},;
            {"36","SIGAQNC ","Controle de Nao-Conformidades     "},;
            {"37","SIGAQAD ","Controle de Auditoria             "},;
            {"38","SIGAQCP ","Controle Estatistico de Processos "},;
            {"39","SIGAOMS ","Gestao de Distribuicao            "},;
            {"40","SIGACSA ","Cargos e Salarios                 "},;
            {"41","SIGAPEC ","Auto Pecas                        "},;
            {"42","SIGAWMS ","Gestao de Armazenagem             "},;
            {"43","SIGATMS ","Gestao de Transporte              "},;
            {"44","SIGAPMS ","Gestao de Projetos                "},;
            {"45","SIGACDA ","Controle de Direitos Autorais     "},;
            {"46","SIGAACD ","Automacao Coleta de Dados         "},;
            {"47","SIGAPPAP","PPAP                              "},;
            {"48","SIGAREP ","Replica                           "},;
            {"49","SIGAGAC ","Gerenciamento Academico           "},;
            {"50","SIGAEDC ","Easy DrawBack Control             "},;
            {"97","SIGAESP ","Especificos                       "},;
            {"98","SIGAESP1","Especificos I                     "}}
               

Return(aReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fAcessos ºAutor  ³Carlos G. Berganton º Data ³  16/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna os Acessos dos Sistema                             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAcessos()

Local aReturn

aReturn := {"Excluir Produtos             ",;
            "Alterar Produtos             ",;
            "Excluir Cadastros            ",;
            "Alterar Solicit. Compras     ",;
            "Excluir Solicit. Compras     ",;
            "Alterar Pedidos Compras      ",;
            "Excluir Pedidos Compras      ",;
            "Analisar Cotacoes            ",;
            "Relat Ficha Cadastral        ",;
            "Relat Bancos                 ",;
            "Relacao Solicit. Compras     ",;
            "Relacao de Pedidos de Compras",;
            "Alterar Estruturas           ",;
            "Excluir Estruturas           ",;
            "Alterar TES                  ",;
            "Excluir TES                  ",;
            "Inventario                   ",;
            "Fechamento Mensal            ",;
            "Proc Diferenca de Inventario ",;
            "Alterar Pedidos de Venda     ",;
            "Excluir Pedidos de Venda     ",;
            "Alterar Helps                ",;
            "Substituicao de Titulos      ",;
            "Inclusao de Dados Via F3     ",;
            "Rotina de Atendimento        ",;
            "Proc. Troco                  ",;
            "Proc. Sangria                ",;
            "Bordero Cheques Pre-Datado   ",;
            "Rotina de Pagamento          ",;
            "Rotina de Recebimento        ",;
            "Troca de Mercadorias         ",;
            "Acesso Tabela de Precos      ",;
            "Abortar c/ Alt-C/Ctrl-Brk    ",;
            "Retorno Temporario p/ o DOS  ",;
            "Acesso Condicao Negociada    ",;
            "Alterar DataBase do Sistema  ",;
            "Alterar Empenhos de OP's     ",;
            "Pode Utilizar Debug          ",;
            "Form. Precos Todos os Niveis ",;
            "Configura Venda Rapida       ",;
            "Abrir/Fechar Caixa           ",;
            "Excluir Nota/Orc LOJA        ",;
            "Alterar Bem Ativo Fixo       ",;
            "Excluir Bem Ativo Fixo       ",;
            "Incluir Bem Via Copia        ",;
            "Tx Juros Condicao Negociada  ",;
            "Liberacao Venda Forcad TEF   ",;
            "Cancelamento Venda TEF       ",;
            "Cadastra Moeda na Abertura   ",;
            "Altera Num. da NF            ",;
            "Emitir NF Retroativa         ",;
            "Excluir Baixa - Receber      ",;
            "Excluir Baixa - Pagar        ",;
            "Incluir Tabelas              ",;
            "Alterar Tabelas              ",;
            "Excluir Tabelas              ",;
            "Incluir Contratos            ",;
            "Alterar Contratos            ",;
            "Excluir Contratos            ",;
            "Uso Integracao SIGAEIC       ",;
            "Inclui Emprestimo            ",;
            "Alterar Emprestimo           ",;
            "Excluir Emprestimo           ",;
            "Incluir Leasing              ",;
            "Alterar Leasing              ",;
            "Excluir Leasing              ",;
            "Incluir Imp. Nao Financ.     ",;
            "Alterar Imp. Nao Financ.     ",;
            "Excluir Imp. Nao Financ.     ",;
            "Incluir Imp. Financ.         ",;
            "Alterar Imp. Financ.         ",;
            "Excluir Imp. Financ.         ",;
            "Incluir Imp. Fin.Export      ",;
            "Alterar Imp. Fin.Export      ",;
            "Excluir Imp. Fin.Export      ",;
            "Incluir Contrato             ",;
            "Alterar Contrato             ",;
            "Excluir Contrato             ",;
            "Lancar Taxa Libor            ",;
            "Consolidar Empresas          ",;
            "Incluir Cadastros            ",;
            "Alterar Cadastros            ",;
            "Incluir Cotacao Moedas       ",;
            "Alterar Cotacao Moedas       ",;
            "Excluir Cotacao Moedas       ",;
            "Incluir Corretoras           ",;
            "Alterar Corretoras           ",;
            "Excluir Corretoras           ",;
            "Incluir Imp./Exp./Cons       ",;
            "Alterar Imp./Exp./Cons       ",;
            "Excluir Imp./Exp./Cons       ",;
            "Baixar Solicitacoes          ",;
            "Visualiza Arquivo Limite     ",;
            "Imprime Doctos. Cancelados   ",;
            "Reativa Doctos. Cancelados   ",;
            "Consulta Doctos. Obsoletos   ",;
            "Imprime Doctos. Obsoletos    ",;
            "Consulta Doctos. Vencidos    ",;
            "Imprime Doctos. Vencidos     ",;
            "Def. Laudo Final Entrega     ",;
            "Imprime Param Relatorio      ",;
            "Transfere Pendencias         ",;
            "Usa Relatorio por E-Mail     "}
                                        
Return(aReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fCabec   ºAutor  ³Carlos G. Berganton º Data ³  18/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Quebra de Pagina e Imprime Cabecalho                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCabec(nLin,nLimite)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . . ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLin > nLimite 
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 6
Endif

Return
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetMnu   ºAutor  ³Carlos G. Berganton º Data ³  15/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem dados de um arquivo .mnu                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetMnu(cArq,cUsuario)

Local aRet := {}
Local aTmp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o Arquivo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cArq)
   ft_fuse(cArq)
Else
   ApMsgAlert("Arquivo "+AllTrim(cArq)+" nao foi encontrado. Usuario "+AllTrim(cUsuario)+".")
   Return({})
Endif   

While ! ft_feof()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Le linha do Arquivo ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cBuff := ft_freadln()
   aTmp := {}
     
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Array com Dados da Linha ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aAdd(aTmp,Substr(cBuff,01,02))
   aAdd(aTmp,Substr(cBuff,03,18))
   aAdd(aTmp,Substr(cBuff,21,10))
   aAdd(aTmp,Substr(cBuff,31,01))
   aAdd(aTmp,{})
   For i:=32 to 89 Step 3
      If Substr(cBuff,i,3)<>"..."
         aAdd(aTmp[5],Substr(cBuff,i,3))
      Endif
   Next
   aAdd(aTmp,Substr(cBuff,122,10))

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Abastece Array de Retorno ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aAdd(aRet,aTmp)
     
   ft_fskip()
EndDo

ft_fuse()

Return(aRet)
                          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1³ Autor ³ Carlos G. Berganton   ³ Data ³ 15/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(CPerg)

Local aArea	    := GetArea()
Local aRegs		:= {}
Local i

AAdd(aRegs,{"01","Do ID..............?","mv_ch1","C",06,0,0,"G","mv_par01",""   ,""       ,"USR"})
AAdd(aRegs,{"02","Ate ID.............?","mv_ch2","C",06,0,0,"G","mv_par02",""   ,""       ,"USR"})
aadd(aRegs,{"03","Do Usuário.........?","mv_ch3","C",15,0,0,"G","mv_par03",""   ,""       ,"USN"})
aadd(aRegs,{"04","Ate Usuário........?","mv_ch4","C",15,0,0,"G","mv_par04",""   ,""       ,"USN"})
aadd(aRegs,{"05","Do Grupo...........?","mv_ch5","C",06,0,0,"G","mv_par05",""   ,""       ,"GRP"}) 
aadd(aRegs,{"06","Ate Grupo..........?","mv_ch6","C",06,0,0,"G","mv_par06",""   ,""       ,"GRP"}) 
AAdd(aRegs,{"07","Imprime Horarios...?","mv_ch7","N",01,0,0,"C","mv_par07","Sim","Nao"    ,""   }) 
AAdd(aRegs,{"08","Imprime Emp/Filiais?","mv_ch8","N",01,0,0,"C","mv_par08","Sim","Nao"    ,""   }) 
AAdd(aRegs,{"09","Imprime Modulos....?","mv_ch9","N",01,0,0,"C","mv_par09","Sim","Nao"    ,""   }) 
AAdd(aRegs,{"10","Imprime Acessos....?","mv_cha","N",01,0,0,"C","mv_par10","Sim","Nao"    ,""   }) 
AAdd(aRegs,{"11","Imprime Menus......?","mv_chb","N",01,0,0,"C","mv_par11","Sim","Nao"    ,""   }) 

dbSelectArea("SX1")
dbSetOrder(1)
For i:=1 to Len(aRegs)
	dbSeek(cPerg+aRegs[i][1])
	If !Found() .or. aRegs[i][2]<>X1_PERGUNT .or. aRegs[i][01]<>X1_ORDEM
		RecLock("SX1",!Found())
           SX1->X1_GRUPO   := cPerg
           SX1->X1_ORDEM   := aRegs[i][01]
           SX1->X1_PERGUNT := aRegs[i][02]
           SX1->X1_VARIAVL := aRegs[i][03]
           SX1->X1_TIPO    := aRegs[i][04]
           SX1->X1_TAMANHO := aRegs[i][05]
           SX1->X1_DECIMAL := aRegs[i][06]
           SX1->X1_PRESEL  := aRegs[i][07]
           SX1->X1_GSC     := aRegs[i][08]
           SX1->X1_VAR01   := aRegs[i][09]
           SX1->X1_DEF01   := aRegs[i][10]
           SX1->X1_DEF02   := aRegs[i][11]
           SX1->X1_F3      := aRegs[i][12]
		MsUnlock()
	Endif
Next
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Parametros Excedentes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While .t.
   dbSeek(cPerg+StrZero(Len(aRegs)+1,2),.t.)
   If X1_GRUPO==cPerg .and. Val(X1_ORDEM)>Val(aRegs[Len(aRegs)][1])
      RecLock("SX1",.f.)
         dbDelete()
      MsUnlock()
   Else
      Exit
   Endif
End

RestArea(aArea)

Return
               
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSXB³ Autor ³ Marcos R. Coelho      ³ Data ³ 31/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as consultas inclu¡ndo-as caso n„o existam        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustSXB()


local nXX
local aAreaSXB	:= SXB->( GetArea() )
Local aRegsSXB  := {}
Local cAliasSXB := "USN"

//				|ALIAS	|TIPO	|SEQ	|COLUNA	|DESCRI		|DESCSPA	|DESCENG	|CONTEM
aadd(aRegsSXB,	{	cAliasSXB, "1",	"01",	"US",	"Usuários",	"Usuários",	"Users",	""		})
aadd(aRegsSXB,	{	cAliasSXB, "5",	"01",	"",		"",			"",			"",			"NAME"	})

SXB->( dbsetorder(1) )
for nXX := 1 to len( aRegsSXB )
	if ! SXB->( dbseek( aRegsSXB[nXX,1] + aRegsSXB[nXX,2] + aRegsSXB[nXX,3] ) )
		RecLock("SXB",.T.)
		SXB->XB_ALIAS	:= aRegsSXB[nXX,1]
		SXB->XB_TIPO	:= aRegsSXB[nXX,2]
		SXB->XB_SEQ		:= aRegsSXB[nXX,3]
		SXB->XB_COLUNA	:= aRegsSXB[nXX,4]
		SXB->XB_DESCRI	:= aRegsSXB[nXX,5]
		SXB->XB_DESCSPA	:= aRegsSXB[nXX,6]
		SXB->XB_DESCENG	:= aRegsSXB[nXX,7]
		SXB->XB_CONTEM	:= aRegsSXB[nXX,8]
		SXB->( MsUnlock() )
	endif
next nXX

SXB->( RestArea( aAreaSXB ) )

return Nil


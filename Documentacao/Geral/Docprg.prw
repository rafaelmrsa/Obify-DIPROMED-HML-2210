#include "rwmake.ch"  
#DEFINE N_BUFFER 1500

User Function Docprg()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DOCPRG   ³ Autor ³ Alexsandro Campos     ³ Data ³ 25/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Documentacao Automatica de RDMAKES                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACFG                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber Neves ³22/06/00³XXXXXX³ Inclusao de tela com explicativo       ³±±
±±³              ³        ³      ³ geral do programa e alteracao dos nomes³±±
±±³              ³        ³      ³ utilizados em arquivos.                ³±±
±±³              ³        ³      ³ Inclusao de regua de processamento.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

DbSelectArea("SX2")
Set Filter to
dbclearind()
c_Ind:="SX2"+SM0->M0_CODIGO+"0"  

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 30/07/01 ==> #DEFINE N_BUFFER 1500

DbSetIndex(c_Ind)

// ALTERACAO EM 04/10/99 PARA RODAR TAMBEM NA VERSAO WINDOWS
C_SAY   := "Verificando...                                   "
C_TITLE := "Documentacao Automatica de Programas RDMAKE"

#IFDEF WINDOWS
       @ 200,1 TO 380,450 DIALOG oProcDoc TITLE OemToAnsi("Documentacao - RDMAKES")
       @ 02,10 TO 060,220

       @ 10,018 Say "Esta rotina gera um arquivo com o nome DOCPRG.TXT, contendo os "
       @ 18,018 Say "programas que estao no padrao RDMAKE. Os programas-fonte"
       @ 26,018 Say "deverao estar no diretorio SIGAADV\RDMAKES."
       @ 34,018 Say ""
       @ 42,018 Say "Especifico para a Microsiga Software S/A."

       @ 70,150 BMPBUTTON TYPE 01 ACTION (THEDOC(),Close(oProcDoc))// Substituido pelo assistente de conversao do AP5 IDE em 30/07/01 ==>        @ 70,150 BMPBUTTON TYPE 01 ACTION Execute(THEDOC)
       @ 70,180 BMPBUTTON TYPE 02 ACTION Close(oProcDoc)
       Activate Dialog oProcDoc Centered
       RETURN

// Substituido pelo assistente de conversao do AP5 IDE em 30/07/01 ==>        Function THEDOC
Static Function THEDOC()
       Processa({||ProcDOC()},"Gerando "+"DOCPRG.txt")// Substituido pelo assistente de conversao do AP5 IDE em 30/07/01 ==>        Processa({||Execute(ProcDOC)},"Gerando "+"DOCPRG.txt")
       Return

// Substituido pelo assistente de conversao do AP5 IDE em 30/07/01 ==>        Function ProcDOC
Static Function ProcDOC()

#ELSE
       DRAWADVWINDOW(C_TITLE,10,02,18,78)

       @ 012,005 SAY "Este programa tem por objetivo documentar programas que estao no padrao" 
       @ 013,005 SAY "RDMAKE. Os programas-fonte deverao estar no diretorio  SIGAADV/RDMAKES."
       @ 014,005 SAY "Ser  gerado um arquivo TXT 'DOCPRG.TXT'        "
       @ 016,005 SAY "Programa: "

       A_CA:={"Confirma",;
              "Abandona"}
       N_OK:=Menuh(a_CA,18,05,"B/W,W+/N,R/W","CA","",1)

       IF (N_OK>1) .OR. (LASTKEY()==27)
          RETURN
       ENDIF

#ENDIF


a_p:=Directory("RDMAKES\*.PR*")

a_a:={}
a_p:=aEval( a_p, {|_e| aAdd(a_a,_e[1])} )
a_p:=aClone(a_a)
a_p:=aSort(a_p,,,{|_x,_y| _x<=_y})
n_Len:=Len(a_p)

n_h:=fCreate("DOCPRG.TXT")

c_Line := Replicate("-",60)

#IFDEF WINDOWS
       ProcRegua(n_Len)
#ELSE
       SetRegua(n_Len)
#ENDIF

For _i := 1 to n_Len

    #IFDEF WINDOWS
           IncProc()
    #ELSE
           IncRegua()
    #ENDIF

    c_buffer := space(N_BUFFER)

    H_ler:=fOpen("rdmakes\"+a_p[_i] , 0)  

    
    fRead(H_Ler,@c_Buffer,N_BUFFER)
    
    c_Prog := space(15000)
    
    fRead(H_Ler,@c_Prog,15000)

    c_Prog:=upper(c_Buffer+c_Prog)
    
    a_Used:={}
    
    While !Empty(n_at:=at("DBSELECTAREA",c_Prog))
        if Empty(_n:=aScan(a_Used,{|_e|_e==Subs(c_Prog,n_at+Len("DbSelectArea")+2,5)}))
           aAdd(a_Used,Subs(c_Prog,n_at+Len("DbSelectArea")+2,5))
        Endif
        c_Prog:=Subs(c_Prog,n_at+Len("DbSelectArea")+7,Len(c_Prog))
    Enddo
    
    if !Empty(a_Used)
        For _k:=1 to Len(a_Used)
            While !Empty(n_at:=at(" ",a_Used[_k]))
                a_Used[_k]:=Stuff(a_Used[_k],n_at,1,"")
            Enddo
            While !Empty(n_at:=at('"',a_Used[_k]))
                a_Used[_k]:=Stuff(a_Used[_k],n_at,1,"")
            Enddo
            While !Empty(n_at:=at("'",a_Used[_k]))
                a_Used[_k]:=Stuff(a_Used[_k],n_at,1,"")
            Enddo
            a_Used[_K]:=alltrim(a_Used[_k])
            For _s := 1 to Len(a_Used[_k])
                if ((asc(subs(a_Used[_k],_s,1))<48).or.(asc(subs(a_Used[_k],_s,1))>122))
                        a_Used[_k]:=Stuff(a_Used[_k],_s,1,"")
                Endif
            Next
        Next
    Endif

    #IFDEF WINDOWS
           Refresher()// Substituido pelo assistente de conversao do AP5 IDE em 30/07/01 ==>            Execute(Refresher)
    #ELSE
           SetColor("b/bg")
           @ 016,015 say a_p[_i]+" documentado!"+Space(30)
    #ENDIF  
    
    fClose(H_Ler)
    
    if Empty(n_at1:=at("/*",c_Buffer))
        c_Bloco :="Programa sem documentacao interna!"
        c_Buffer:=a_p[_i]+chr(13)+chr(10)+c_Line+chr(13)+chr(10)+c_Bloco+chr(13)+chr(10)+chr(13)+chr(10)
        //
        fWrite(n_H,c_Buffer,Len(c_Buffer))
        Loop
    Endif
    
    n_at:=at("*/",Subs(c_Buffer,n_at1+2,Len(c_Buffer)))
    //
    c_Bloco:="Programa com documentacao interna OK! "+ chr(13)+ chr(10)+subs(c_Buffer,n_at1,n_at)
    //
    c_Buffer:=a_p[_i]+chr(13)+chr(10)+c_Line+chr(13)+chr(10)+c_Bloco+chr(13)+chr(10)
    //
    

/*    
    For _k:=1 to Len(c_Buffer)
        if (asc( Subs(c_Buffer,_k,1) )< 32).or.(asc( Subs(c_Buffer,_k,1) ) > 167)
            if !subs(c_Buffer,_k,1)$(chr(13)+chr(10))
                c_Buffer:=Stuff(c_Buffer,_k,1," ")
            Endif
        Endif
    Next
*/    
    
    if !Empty(a_Used)
        x_Alias:=alias()
        c_Buffer:=c_Buffer+"Arquivos Utilizados: "+chr(13)+chr(10)

        DbSelectArea("SX2") ; DbSetOrder(1)

        For _k:=1 to Len(a_Used)
            if DbSeek(Left(Upper(a_Used[_k]),3))
                c_Buffer:=c_Buffer+a_Used[_k]+" "+SX2->X2_NOME+Chr(13)+Chr(10)
            Else
                c_Buffer:=c_Buffer+a_Used[_k]+" arq.nao encontrado no SX2"+Chr(13)+Chr(10)
            Endif
        Next  

        c_Buffer:=c_Buffer+chr(13)+chr(10)
        DbSelectArea(x_Alias)

    Endif
    
    For _s:=1 to Len(c_Buffer)
        c_String:=""
        n_at:=at(Chr(13)+Chr(10),Subs(c_Buffer,_s,Len(c_Buffer)))
        n_at0:=n_at
        n_at:=n_at+_s-1
        c_String:=Subs(c_Buffer,_s,n_at0-1)

        if Empty(alltrim(c_String)).AND.(Len(c_String)>3)
            c_Buffer:=Stuff(c_Buffer,_s,n_at0+1,"")
        Else 
            _s:=_s+n_at0  //+1
        Endif

    Next
    
    //
    fWrite(n_H,c_Buffer,Len(c_Buffer))
    //
Next

fClose(n_H)


return


// Substituido pelo assistente de conversao do AP5 IDE em 30/07/01 ==> Function Refresher
Static Function Refresher()

   C_SAY:=a_p[_i]+" Documentado !"
   
Return   




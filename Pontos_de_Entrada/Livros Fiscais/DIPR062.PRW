/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR062  ³ Autor ³ Maximo Canuto V. Neto ³ Data ³ 14/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Revisão de Comissão Kimberly Clarck                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR062                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        *±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ,±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPR062()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Revisão de Comissão Kimberly Clarck...",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com a comissão por vendedor sobre os produtos KC..",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local cUserAut   := GetMV("MV_URELFAT") // MCVN - 04/05/09 

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR062"
//Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR062"
Private cString    := "SD2"
Private m_pag      := 1

// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR62","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU   

// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
EndIF 

AjustaSX1(cPerg)            // Verifica perguntas. Se nao existe INCLUI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                     ³
//³ mv_par01            // do vendedor 1                     ³
//³ mv_par02            // at‚ o vendedor 1                  ³
//³ mv_par03            // da data da baixa                  ³
//³ mv_par04            // at‚ a data da baixa               ³
//³ mv_par05            // do c¢digo                         ³
//³ mv_par06            // at‚ o c¢digo                      ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  


If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel()},Titulo)

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()

Local _cDoc   := ''

// Gerando query principal

QRY1 :=        "SELECT "+RetSQLName("SD2")+".*, F2_VALBRUT, B1_DESC, B1_PRVMINI, B1_PRVPROM, B1_PRVSUPE, A1_NOME,  E1_BAIXA, E1_VENCREA, E1_VEND1, E1_VEND2, C6_MARGATU, C6_PRCMIN, A3_NREDUZ, C5_MARGATU"
QRY1 := QRY1 + " FROM " + RetSQLName("SD2")+', '+RetSQLName("SF2")+', '+RetSQLName("SB1")+', '+RetSQLName("SA1")+', '+RetSQLName("SE1")+ ', '+RetSQLName("SC6")+ ', '+RetSQLName("SA3")+ ', '+RetSQLName("SC5")
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_FILIAL = '"+xFilial('SD2')+"' and " 
QRY1 := QRY1 + RetSQLName('SC6')+".C6_FILIAL = '"+xFilial('SC6')+"' and " 
QRY1 := QRY1 + RetSQLName('SC5')+".C5_FILIAL = '"+xFilial('SC5')+"' and " 
QRY1 := QRY1 + RetSQLName('SF2')+".F2_FILIAL = '"+xFilial('SF2')+"' and "
QRY1 := QRY1 + RetSQLName('SD2')+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName('SC6')+".D_E_L_E_T_ <> '*' and "   
QRY1 := QRY1 + RetSQLName('SC5')+".D_E_L_E_T_ <> '*' and "   
QRY1 := QRY1 + RetSQLName('SF2')+".D_E_L_E_T_ <> '*' and "   
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VEND1    between '"+mv_par01+"' and '"+mv_par02+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_BAIXA    between '"+DTOS(mv_par03)+"' and '"+DTOS(mv_par04)+"' And  "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_COD      between '"+mv_par05+"' and '"+mv_par06+"' and "
QRY1 := QRY1 + RetSQLName('SA3')+".A3_TIPO     = 'E' and "
QRY1 := QRY1 + RetSQLName('SB1')+".B1_PROC     = '000366' and ("
QRY1 := QRY1 + RetSQLName('SE1')+".E1_PARCELA  = '' OR "+ RetSQLName('SE1')+".E1_PARCELA  = 'A') and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_DOC      = "+RetSQLName('SF2')+".F2_DOC and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_SERIE    = "+RetSQLName('SF2')+".F2_SERIE and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_PEDIDO   = "+RetSQLName('SC5')+".C5_NUM and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_PEDIDO   = "+RetSQLName('SC6')+".C6_NUM and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_DOC      = "+RetSQLName('SC6')+".C6_NOTA and " 
QRY1 := QRY1 + RetSQLName('SD2')+".D2_SERIE    = "+RetSQLName('SC6')+".C6_SERIE and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_COD      = "+RetSQLName('SC6')+".C6_PRODUTO and "   
QRY1 := QRY1 + RetSQLName('SD2')+".D2_DOC      = "+RetSQLName('SE1')+".E1_NUM and " 
QRY1 := QRY1 + RetSQLName('SD2')+".D2_SERIE    = "+RetSQLName('SE1')+".E1_PREFIXO and " 
QRY1 := QRY1 + RetSQLName('SD2')+".D2_CLIENTE  = "+RetSQLName('SA1')+".A1_COD and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_LOJA     = "+RetSQLName('SA1')+".A1_LOJA and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_COD      = "+RetSQLName('SB1')+".B1_COD and " 
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VEND1    = "+RetSQLName('SA3')+".A3_COD and "
QRY1 := QRY1 + RetSQLName('SD2')+".D2_ITEMPV   = "+RetSQLName('SC6')+".C6_ITEM "




	QRY1 := QRY1 + "order by E1_VEND1, E1_BAIXA, D2_DOC, D2_SERIE, D2_COD"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query


// Gerando query dos títulos

QRY2 :=        "SELECT E1_NUM, E1_PREFIXO, E1_EMISSAO, E1_VENCREA, E1_BAIXA, E1_PARCELA, E1_VALOR, E1_VEND1, E1_VEND2 "
QRY2 := QRY2 + " FROM " + RetSQLName("SE1")
QRY2 := QRY2 + " WHERE "
QRY2 := QRY2 + RetSQLName('SE1')+".E1_FILIAL = '"+xFilial('SE1')+"' and "
QRY2 := QRY2 + RetSQLName('SE1')+".D_E_L_E_T_ <> '*' and "
QRY2 := QRY2 + RetSQLName('SE1')+".E1_VEND1   between '"+mv_par01+"' and '"+mv_par02+"' and "
QRY2 := QRY2 + RetSQLName('SE1')+".E1_BAIXA   between '"+DTOS(mv_par03)+"' and '"+DTOS(mv_par04)+"' "



	QRY2 := QRY2 + "order by E1_VEND1, E1_NUM, E1_PREFIXO, E1_BAIXA"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query do E1

DbSelectArea("QRY1")
QRY1->(dbGotop())
SetRegua(QRY1->(RecCount()))


	_cTitulo   := "REVISÃO DE COMISSÃO KIMBERLY CLARK    -    " + 'PERIODO: '+dTOc(mv_par03)+' - '+dTOc(mv_par04)
	_cDesc1    := "NF/SERIE    EMISSÃO     COD/LOJA    NOME DO CLIENTE                                                                    VENDEDOR 1                         VENDEDOR 2               PEDIDO    IA DO PEDIDO  
    _cDesc2    := "Produto                                                                        Valor Unit.     Valor Total     % Comissão 1   Valor Comissão 1    % Comissão 2   Valor Comissão 2            IA do Item     Menor Preço
    _cdoc      := '' 
    _cdoc2     := ''
    _cSerie    := '' 
    _cSerie2   := ''
    _cTotCom1  := 0
    _cTotCom2  := 0    
    _cTotNf    := 0 
    _cVend1    := ''
    _cVend2    := ''
    _cNreduz1  := ''
    _cNreduz2  := ''
    _nMenorPrc := 0
    
    
Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*NF/SERIE    Emissao             Cliente                                              Vendedor                          Vendedor2             Pedido      IA PEDIDO    Periodo: 99/99/9999 - 99/99/9999
    *Produto                                                                       % Comissão 1   Valor Comissão 1  % Comissão 2   Valor Comissão 2                                                IA
	*999999  99/99/9999  99/99/9999  123456-12 - 1234567890123456789012345678901234567890123456789012345678901     999999 - 123456789012345678901234567890123456  99,999,999.99 
	*999999 12345678901234567890123456789012345678901234567890123456789012345678912345 99.99      99,999,999.99  99.99      99,999,999.99  123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
	
	// Nota Fiscal
	If _cDoc <> QRY1->D2_DOC .OR. _cSerie <> QRY1->D2_SERIE
		@ li,000 PSay QRY1->D2_DOC+'/'+QRY1->D2_SERIE
		@ li,012 PSay SubStr(QRY1->D2_EMISSAO,7,2)+'/'+SubStr(QRY1->D2_EMISSAO,5,2)+'/'+SubStr(QRY1->D2_EMISSAO,1,4)	
		@ li,024 PSay QRY1->D2_CLIENTE+'-'+QRY1->D2_LOJA +' - '+QRY1->A1_NOME
	   	@ li,116 PSay QRY1->E1_VEND1+'-'+A3_NREDUZ	 
  
 	// Buscando nome reduzido do Vendedor 2
 		If  !Empty(QRY1->E1_VEND2)
   	
    		_cVend2   := QRY1->E1_VEND2
    
			SA3->(dbSetOrder(1))
			SA3->(dbSeek(xfilial("SA3")))
			SA3->(DbGoTop())
	   			Do  While SA3->(!Eof())
	          
         			If SA3->A3_COD = _cVend2
	    	 			_cNreduz2 := SA3->A3_NREDUZ
	     			EndIf  
	     
	     			SA3->(DbSkip())
	   
	   			EndDo 
         @ li,151 PSay QRY1->E1_VEND2+'-'+_cNreduz2			 
      Endif
         
    // Imprimindo restante das informações da Query QRY1.	
		@ li,179 PSay QRY1->D2_PEDIDO
        @ li,189 PSay QRY1->C5_MARGATU PICTURE '@E 999.9999'			
  

	    _cDoc2   := QRY1->D2_DOC
        _cSerie2 := QRY1->D2_SERIE
		li := li+2
	Endif
	   
		
	//Itens da Nota Fiscal
	@ li,000 PSay SUBSTR(QRY1->D2_COD,1,6)+'  '+QRY1->B1_DESC
    @ li,075 PSay QRY1->D2_PRCVEN PICTURE '@E 99,999,999.9999'
    @ li,092 PSay QRY1->D2_TOTAL  PICTURE '@E 99,999,999.99'
	@ li,114 PSay QRY1->D2_COMIS1 PICTURE '@E 99.99'
    @ li,128 PSay (QRY1->D2_TOTAL / 100)*QRY1->D2_COMIS1 PICTURE '@E 99,999,999.99'  
    
    // Imprimindo dados do vendedor 2 se existir.
       	If  !Empty(QRY1->E1_VEND2)
			@ li,146 PSay QRY1->D2_COMIS2 PICTURE '@E 99.99'                                   
    		@ li,161 PSay (QRY1->D2_TOTAL / 100)*QRY1->D2_COMIS2 PICTURE '@E 99,999,999.99'
    	Endif
    		
	@ li,189 PSay QRY1->C6_MARGATU  PICTURE '@E 999.9999'
	   
  // Verificando qual o menor preço
  
  /*  _nMenorPrc := Min(QRY1->B1_PRVSUPE,Min(QRY1->B1_PRVPROM,QRY1->B1_PRVMINI))   
  		     If _nMenorPrc = 0
         		    _nMenorPrc := Min(QRY1->B1_PRVPROM,QRY1->B1_PRVMINI)
         		        If _nMenorPrc = 0                               
           		               _nMenorPrc := Min(QRY1->B1_PRVSUPE,QRY1->B1_PRVMINI)
                       		        If _nMenorPrc = 0                                          		                  
                              		       _nMenorPrc := Min(QRY1->B1_PRVSUPE,QRY1->B1_PRVPROM)
                              		EndIf
                        EndIf
             Endif       */        
                       
     
      @ li,202 PSay QRY1->C6_PRCMIN  PICTURE '@E 999,999.9999'
   	
   
   	
    // Calculanto o total das comissãoes 
    _cTotCom1 := _cTotCom1 + ((QRY1->D2_TOTAL / 100)*QRY1->D2_COMIS1)
    _cTotCom2 := _cTotCom2 + ((QRY1->D2_TOTAL / 100)*QRY1->D2_COMIS2)   
		
		If _cDoc   <> QRY1->D2_DOC .OR. _cSerie <> QRY1->D2_SERIE
           _cDoc   := QRY1->D2_DOC 
           _cSerie := QRY1->D2_SERIE
	    EndIf
	
	li := li+1
	
	QRY1->(DbSkip())
	
	If _cDoc <> QRY1->D2_DOC  .OR. _cSerie <> QRY1->D2_SERIE
	  
		
  //Buscando os títulos baixados - SE1		
	   		 DbSelectArea("QRY2")
			 QRY2->(dbGotop())
 		
	li := li+1 

			       Do  While QRY2->(!Eof())
	                 
        		      If _cDoc2 == QRY2->E1_NUM .AND. _cSerie2 == QRY2->E1_PREFIXO  
        		          
                	 
                         If QRY2->E1_PARCELA = ' ' 
                            @ li,000 PSay "PARCELA ÚNICA" 
                         Else
                            @ li,000 PSay "PARCELA: " 
                            @ li,011 PSay QRY2->E1_PARCELA
                         Endif   
                         @ li,022 PSay "DATA DA BAIXA: "                          
                         @ li,038 PSay SubStr(QRY2->E1_BAIXA,7,2)+'/'+SubStr(QRY2->E1_BAIXA,5,2)+'/'+SubStr(QRY2->E1_BAIXA,1,4)
                         @ li,054 PSay "VALOR DO TÍTULO: " 
                         @ li,075 PSay QRY2->E1_VALOR PICTURE '@E 99,999,999.99'                          
                      
	                     _cTotNf := _cTotNf + QRY2->E1_VALOR
                        li := li+1 
			          EndIf 
	         
	    	          QRY2->(DbSkip()) 
	
	               Enddo 
   	
	@ li,000 PSay Replicate('-',limite)
	li+=2
	EndIf
	     		
EndDo
    
    
Roda(0,"Bom trabalho!",tamanho)

dbSelectArea("SA3")
dbSelectArea("QRY2")
dbSelectArea("QRY1") 
SA3->(dbCloseArea())
QRY2->(dbCloseArea())
QRY1->(dbCloseArea())

Return(.T.)


//////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aADD(aRegs,{cPerg,"01","Do Vend1       ?","","","mv_ch1","C",6, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aADD(aRegs,{cPerg,"02","Ate vend1      ?","","","mv_ch2","C",6, 0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"03","Data Baixa de  ?","","","mv_ch3","D",8, 0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Data Baixa ate ?","","","mv_ch4","D",8, 0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"05","De Produto     ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"06","Ate Produto    ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

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

dbSelectArea(_sAlias)
Return
////////////////////////////////////////////////////////////////////////////////////////////////////////

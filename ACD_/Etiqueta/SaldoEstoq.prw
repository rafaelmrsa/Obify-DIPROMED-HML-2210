#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVPRINT.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ`ÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ºAutor  ³  Emerson Leal Bruno			  º Data ³  08/05/2009º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Etiqueta de Produto avulsa saldo			  º±±
±±º          ³ 					                      º±±          
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  ACd                                                       º±±
±±Obs: 			   													  	  ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SaldoEstoq() 

Private oDlg1  
Private MV_PAR01  	   	:= Space(06)
Private MV_PAR02  	   	:= Space(15)
//Private MV_PAR03  	   	:= Space(10) 	 	
Private MV_PAR05		:= Space(30)
Private MV_PAR06		:= 0   
Private MV_PAR07  	   	:= "ZZZZZZZZZZZZZZZ"
Private MV_PAR08  	   	:= "01"
Private MV_PAR09  	   	:= "01" 
Private MV_PAR10  	   	:= Space(15) 
Private MV_PAR11  	   	:= "ZZZZZZZZZZZZZZZ"   
Private nQtdeEti		:= 0    
Private aArrPar 		:= {}  
Private cDataValid            
Private nQtde			:= 1

		  	 	                    
Private cLocalImp		:= Space(06)
//Private dDataTeste      := CTOD("  /  /  ")    
Private cOpitemseq		  
                                                                                                         
DEFINE MSDIALOG oDlg1 TITLE "Saldo em Estoque inicial para produtos, 'Etiqueta'. " OF oMainWnd PIXEL FROM 080,010 TO 420,480		
DEFINE FONT oBold  NAME "Arial" SIZE 0, -12 BOLD

@ 005,003 TO 165,234 PROMPT "Saldo do Produto"  PIXEL OF oDlg1 	// Contorno Acima
                          
@ 015,010 SAY "Endereco de :"               	    	      			SIZE 555,10 PIXEL OF oDlg1 FONT oBold     	
@ 015,060 MSGET oOP	  	VAR MV_PAR10	WHEN .T. OF oDlg1 				SIZE 045,10 PIXEL F3 "SBE"

@ 040,010 SAY "Endereco ate:"               	    	      			SIZE 555,10 PIXEL OF oDlg1 FONT oBold   
@ 040,060 MSGET oOP	  	VAR MV_PAR11	WHEN .T. OF oDlg1 				SIZE 045,10 PIXEL F3 "SBE" 

@ 065,010 SAY "Armazem de:"               	    	       				SIZE 555,10 PIXEL OF oDlg1 FONT oBold     	
@ 065,060 MSGET oOP	  	VAR MV_PAR08	WHEN .F. OF oDlg1 				SIZE 020,10 PIXEL  //VALID CARREGA(MV_PAR02,MV_PAR07)	    				

@ 090,010 SAY "Armazem ate:"               	    	      	  			SIZE 555,10 PIXEL OF oDlg1 FONT oBold     	
@ 090,060 MSGET oOP	  	VAR MV_PAR09	WHEN .F. OF oDlg1 				SIZE 020,10 PIXEL  //VALID CARREGA(MV_PAR02,MV_PAR07,MV_PAR08,MV_PAR09)	    				         

@ 115,010 SAY "Produto de :"               	    	      				SIZE 555,10 PIXEL OF oDlg1 FONT oBold     		//Produto
@ 115,060 MSGET oOP	  	VAR MV_PAR02	WHEN .T. OF oDlg1 				SIZE 070,10 PIXEL F3 "SB1" //VALID CARREGA(MV_PAR02)	    				

@ 140,010 SAY "Produto ate:"               	    	      				SIZE 555,10 PIXEL OF oDlg1 FONT oBold     		//Produto
@ 140,060 MSGET oOP	  	VAR MV_PAR07	WHEN .T. OF oDlg1 				SIZE 070,10 PIXEL F3 "SB1" //VALID CARREGA(MV_PAR02,MV_PAR07)	    				

@ 040,130 SAY "Qtd Etiqueta"		  		      				  		SIZE 555,10 PIXEL OF oDlg1 FONT oBold 	    	//local de Impressao
@ 040,190 MSGET oOP	  	VAR nQtde 		   			 	 Picture "9999" SIZE 030,10	WHEN .T. OF oDlg1  PIXEL 

@ 090,130 SAY "Local de Impressao"  		      				  		SIZE 555,10 PIXEL OF oDlg1 FONT oBold 	    	//local de Impressao
@ 090,190 MSGET oOP	  	VAR cLocalImp    						 		WHEN .T. OF oDlg1 SIZE 025,10 PIXEL F3 "CB5"

@ 140,140 BUTTON "&Imprimir"    SIZE 36,16 PIXEL ACTION PROCESSA ({|| CARREGA1(MV_PAR02,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11,nQtde)},"Gerando Etiqueta!","Aguarde  Processando....",.T.) // Impressao                                                                                                                              
@ 140,190 BUTTON "&Sair"       	SIZE 36,16 PIXEL ACTION oDlg1:End()     //Sair   

ACTIVATE MSDIALOG oDlg1  CENTERED

Return()               

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function CARREGA1(MV_PAR02,MV_PAR07,MV_PAR08,MV_PAR09,MV_PAR10,MV_PAR11,nQtde)	//Carrega parametros relacionado ao produto.			
/////////////////////////////////////////////////////////////////////////////////////

Local nQtdTotal := 0 
  
cQuery := " SELECT DISTINCT BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_LOTECTL, BF_QUANT " 
cQuery += " FROM " + RetSqlName( "SBF" ) + " SBF " 
cQuery += " WHERE SBF.BF_FILIAL = '"+xFilial('SBF')+"' AND SBF.BF_PRODUTO BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR07+"' AND SBF.BF_LOCAL BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' AND SBF.BF_LOCALIZ BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND SBF.D_E_L_E_T_ = '' AND BF_QUANT > 0 AND BF_LOTECTL <> '' ORDER BY BF_LOCALIZ"
  
If (Select("cQuery") <> 0)
  cQuery->( dbCloseArea() )
EndIf
TcQuery cQuery New Alias "QRYPED"
         
//Total de registros processados,
cQueryS := " SELECT COUNT(*) AS TOTRECNO " //, BF_QUANT
cQueryS += " FROM " + RetSqlName( "SBF" ) + " SBF " 
cQueryS += " WHERE SBF.BF_FILIAL = '"+xFilial('SBF')+"' AND SBF.BF_PRODUTO BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR07+"' AND SBF.BF_LOCAL BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' AND SBF.BF_LOCALIZ BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND SBF.D_E_L_E_T_ = ''  AND BF_QUANT > 0 AND BF_LOTECTL <> ''"

If (Select("cQueryS") <> 0)
  cQuery->( dbCloseArea() )
EndIf
TcQuery cQueryS New Alias "QRYPES"

nQtdTotal := QRYPES->TOTRECNO
QRYPES->(dBCloseArea())                                 

QRYPED->(dbGoTop())       

aArrPar 	:= {}
While ! QRYPED->(Eof())
		DBSELECTAREA("SB1")
		DBSETORDER(1) //B1_FILIAL+B1_COD
		DBSEEK(xFilial("SB1")+QRYPED->BF_PRODUTO)		
		cDesck	:= SB1->B1_DESC	

/* 
	DBSELECTAREA("SB8")
sb		DBSETORDER(1) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL+B8_NUMLOTE
		DBSEEK(xFilial("SB8")+QRYPED->BF_PRODUTO+QRYPED->BF_LOCAL) 

		cDataValid	:= DTOC(SB8->B8_DTVALID)
*/		
       aAdd(aArrPar, { 	QRYPED->BF_PRODUTO			, ;						//Adicionando no array campo 1 
       					cDesck						, ;						//Adicionando no array campo 2        				  
		 			   	QRYPED->BF_LOCAL			, ;						//Adicionando no array campo 3        				  
                       	QRYPED->BF_LOCALIZ			, ;						//Adicionando no array campo 4
                       	QRYPED->BF_LOTECTL			, ;						//Adicionando no array campo 5 
					   	nQtde					    , ;						//Adicionando no array campo 6  
					   	QRYPED->BF_QUANT		  	} )			   			//Adicionando no array campo 7 
//					   	cDataValid					} )						//Adicionando no array campo 8// QTDE DE ETIQUETA PARA CADA PRODUTO  
       QRYPED->( dbSkip() )
EndDo                                      

QRYPED->(dBCloseArea())  

If ( Len(aArrPar) == 0 )
       MsgAlert("Nada encontrado na busca.!") 
       Return
EndIf       

IF !CB5SetImp(cLocalImp) //Verificacao do Local de impressao utilizado na fila de impressao CB5 
   AVISO("Atencao","Local de impressao nao configurado",{"OK"})
   lReturn := .F.  
   Return(lReturn)
EndIf 

PROCESSA ({|| SaldoEt(aArrPar,nQtdTotal)},"Imprimindo Etiqueta","Aguarde  Processando....",.T.)

Return()                                             

///////////////////////////////////////////////////////////////////////////////////
Static Function SaldoEt(aArrPar,nQtdTotal)        
////////////////////////                          

Local cId 		:= ""  
Local cData		:= dtos(dDataBase)  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
Local cData1    := (substr(cData,7,2)+"/"+substr(cData,5,2)+"/"+substr(cData,1,4))
       
ProcRegua(nQtdTotal)//RecCount()nQtde

For i := 1 to len(aArrPar)

	IncProc("Gerando Etiqueta ==> "+aArrPar[i][1])
	    
	U_GERAETIQ(aArrPar[i][1],0,0,aArrPar[i][6],"",aArrPar[i][5],"","","")		
	 
Next			
	
MSCBCLOSEPRINTER()

MsgAlert('Impressao finalizada')

Return()

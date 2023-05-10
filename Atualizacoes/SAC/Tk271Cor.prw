#INCLUDE "PROTHEUS.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271COR  ºAutor  ³Reginaldo Borges    º Data ³  09/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para alterar as cores das lengedas        º±±
±±º          ³ do atendimento Call Center.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function Tk271Cor(cTipoAte)
    
Local aArea    := GetArea()
Local aCores1  := {}

	If cTipoAte == '1'  
						 
						
					
       
       aCores1    := {	{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 1)" , "BR_VERMELHO" },;    // Pendente Sac
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 2)" , "BR_AZUL    " },;    // Pendente Diretoria
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 3)" , "BR_VERDE   " },;    // Atendimento Encerrado
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 9)" , "BR_BRANCO  " },;    // Pendente Qualidade
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 6)" , "BR_LARANJA " },;    // Pendente Transporte
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 7)" , "BR_AMARELO " },;    // Pendente Fiscal
   						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 8)" , "BR_PINK    " },;    // Pendente Financeiro
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 10)" ,"BR_PRETO_1 " },;    // Pendente Esc.Fiscal 
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 11)" ,"BR_PRETO_3 " },;    // Pendente Estoque   						  						 
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 12)" ,"BR_VERDE_ESCURO" },;// Pendente Fornecedor   						  						  						
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 13)" ,"BR_AZUL_CLARO" },;  // Pendente Cliente   						  						  						  						
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 14)" ,"BR_VIOLETA" },;     // Pendente Vendas   						  						  						  						  					
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 15)" ,"BR_PRETO_2" },;     // Pendente Recebimento   						  						  						  						  					
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 16)" ,"BR_PRETO_4" },;     // Pendente Expedição   						  						  						  						  					
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 17)" ,"BR_PRETO_C" },;     // Pendente Compras  						  						  						  						  					
  						{"(EMPTY(SUC->UC_CODCANC) .AND. VAL(SUC->UC_STATUS) == 18)" ,"BR_PRETO_A" },;     // Pendente TI   						  						  						  						  					  						  						
   						{"(!EMPTY(SUC->UC_CODCANC))","BR_CANCEL"		}} 							      // Atendimento Cancelado

   		 				
   	 EndIf					
   						
  						
RestArea(aArea)


RETURN (aCores1) 



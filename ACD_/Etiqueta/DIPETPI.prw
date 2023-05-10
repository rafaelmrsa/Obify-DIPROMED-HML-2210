#include "protheus.ch"
#include "apwizard.ch"  

/*/
{Protheus.doc} DIPETPI
Impressão de etiqueta PI, referênte à OP posicionada.
@type  Function
@author Felipe Almeida
@since 20/12/2019
@version 1.0
/*/

User Function DIPETPI()

    Local cPerg := "XDIPETPI"

    Pergunte(cPerg, .T.)

    Processa({|| IMPETQPI()}, "Imprimindo etiquetas...")

Return 

Static Function IMPETQPI()

    // Variáveis com valor definido
    Local cCodProd  := SC2->C2_PRODUTO
    Local cLoteCT   := SC2->C2_XLOTECT
    Local nQntImp   := MV_PAR01

    // Variáveis com valor indefinido
    Local cCodBar   := ""
    Local cDescProd := ""   
    Local nCont

    DbSelectArea('SB1')
    DbSetOrder(1)
    MsSeek(xFilial('SB1')+SC2->C2_PRODUTO)

    cDescProd := SB1->B1_DESC             
    
    If Empty(cDescProd)
        MsgAlert("A descrição auxiliar para o produto "+cCodProd+" nao foi informada. Impressao cancelada do item!")
        Return
    EndIf
        
    cCodBar	:= PADR(cCodProd,15)+PADR(cLoteCT,10) 

    For nCont := 1 to nQntImp

        MSCBPrinter('ZEBRA','LPT1',,)

        MSCBBEGIN(1,4)      
        
        MSCBSAY(03,04,'CODIGO: '						,"N", "C", "25") 		
        MSCBSAY(18,03,Alltrim(cCodProd)					,"N", "C", "30") // Código produto  				
        MSCBSAY(85,03,'UN'          					,"N", "C", "30")

        MSCBLineH(01,08,97,3)
 		
        MSCBSAY(03,10,Substr(cDescProd,1,60)			,"N", "C", "25") // Descrição  		  
        MSCBSAY(03,14,'Lote: '							,"N", "C", "20")				
        MSCBSAY(18,13,Alltrim(cLoteCT)					,"N", "C", "30") // Código lote   
        	
        MSCBSAYBAR(03,19,cCodBar				  		,"N", "C",08,.F.,.F.,.F., ,2,2,.F.) // Código de Barra
        
        MSCBSAY(88,19,"A" ,"N", "C", "30") // Identificador de impressão manual	                                

        MSCBEND()    
        
    Next nCont

    SB1->(DbCloseArea())

Return 